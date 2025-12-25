package service

import (
    "context"
    "errors"
    "strings"
    "time"

    authv1 "github.com/zenx/backend/proto/auth/v1"
    commonv1 "github.com/zenx/backend/proto/common/v1"
    "github.com/zenx/backend/services/auth-service/internal/store"
    "github.com/zenx/backend/services/auth-service/internal/token"
    "golang.org/x/crypto/bcrypt"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
)

// AuthService implements the auth.v1 gRPC API.
type AuthService struct {
    authv1.UnimplementedAuthServiceServer
    repo   *store.Repository
    tokens *token.Manager
}

// New creates a new AuthService instance.
func New(repo *store.Repository, tokens *token.Manager) *AuthService {
    return &AuthService{repo: repo, tokens: tokens}
}

// RegisterUser creates a user record.
func (s *AuthService) RegisterUser(ctx context.Context, req *authv1.RegisterUserRequest) (*authv1.RegisterUserResponse, error) {
    if req.GetEmail() == "" || req.GetPassword() == "" {
        return nil, status.Error(codes.InvalidArgument, "email and password are required")
    }

    hash, err := bcrypt.GenerateFromPassword([]byte(req.GetPassword()), bcrypt.DefaultCost)
    if err != nil {
        return nil, status.Errorf(codes.Internal, "hash password: %v", err)
    }

    user, err := s.repo.CreateUser(ctx, strings.ToLower(req.GetEmail()), string(hash), optionalString(req.GetDisplayName()))
    if err != nil {
        if errors.Is(err, store.ErrUserExists) {
            return nil, status.Error(codes.AlreadyExists, "user already exists")
        }
        return nil, status.Errorf(codes.Internal, "create user: %v", err)
    }

    return &authv1.RegisterUserResponse{
        UserId:    user.ID.String(),
        CreatedAt: user.CreatedAt.Unix(),
    }, nil
}

// Login validates credentials and issues tokens.
func (s *AuthService) Login(ctx context.Context, req *authv1.LoginRequest) (*authv1.LoginResponse, error) {
    user, err := s.repo.GetUserByEmail(ctx, strings.ToLower(req.GetEmail()))
    if err != nil {
        if errors.Is(err, store.ErrInvalidCredentials) {
            return nil, status.Error(codes.Unauthenticated, "invalid credentials")
        }
        return nil, status.Errorf(codes.Internal, "get user: %v", err)
    }

    if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.GetPassword())); err != nil {
        return nil, status.Error(codes.Unauthenticated, "invalid credentials")
    }

    tokens, err := s.tokens.CreateTokens(user.ID.String())
    if err != nil {
        return nil, status.Errorf(codes.Internal, "create tokens: %v", err)
    }

    if _, err := s.repo.StoreRefreshToken(ctx, user.ID, tokens.RefreshToken, tokens.RefreshExpiry); err != nil {
        return nil, status.Errorf(codes.Internal, "store refresh token: %v", err)
    }

    return &authv1.LoginResponse{
        AccessToken:  tokens.AccessToken,
        RefreshToken: tokens.RefreshToken,
        ExpiresAt:    tokens.AccessExpiry.Unix(),
    }, nil
}

// ValidateToken verifies an access token and returns context.
func (s *AuthService) ValidateToken(ctx context.Context, req *authv1.ValidateTokenRequest) (*authv1.ValidateTokenResponse, error) {
    claims, err := s.tokens.ValidateAccessToken(req.GetAccessToken())
    if err != nil {
        return nil, status.Errorf(codes.Unauthenticated, "invalid token: %v", err)
    }

    userID, _ := claims["sub"].(string)
    if userID == "" {
        return nil, status.Error(codes.Unauthenticated, "missing subject")
    }

    return &authv1.ValidateTokenResponse{
        Valid: true,
        Context: &commonv1.UserContext{
            UserId: userID,
            Roles:  []string{"user"},
        },
    }, nil
}

// RefreshToken exchanges a refresh token for new credentials.
func (s *AuthService) RefreshToken(ctx context.Context, req *authv1.RefreshTokenRequest) (*authv1.LoginResponse, error) {
    claims, err := s.tokens.ValidateRefreshToken(req.GetRefreshToken())
    if err != nil {
        return nil, status.Errorf(codes.Unauthenticated, "invalid refresh token: %v", err)
    }

    userID, _ := claims["sub"].(string)
    if userID == "" {
        return nil, status.Error(codes.Unauthenticated, "missing subject")
    }

    record, err := s.repo.GetRefreshToken(ctx, req.GetRefreshToken())
    if err != nil {
        if errors.Is(err, store.ErrRefreshTokenNotFound) {
            return nil, status.Error(codes.Unauthenticated, "refresh token revoked")
        }
        return nil, status.Errorf(codes.Internal, "lookup refresh token: %v", err)
    }

    if record.ExpiresAt.Before(timeNow()) {
        _ = s.repo.DeleteRefreshToken(ctx, record.ID)
        return nil, status.Error(codes.Unauthenticated, "refresh token expired")
    }

    tokens, err := s.tokens.CreateTokens(userID)
    if err != nil {
        return nil, status.Errorf(codes.Internal, "create tokens: %v", err)
    }

    if err := s.repo.DeleteRefreshToken(ctx, record.ID); err != nil {
        return nil, status.Errorf(codes.Internal, "revoke old refresh token: %v", err)
    }

    if _, err := s.repo.StoreRefreshToken(ctx, record.UserID, tokens.RefreshToken, tokens.RefreshExpiry); err != nil {
        return nil, status.Errorf(codes.Internal, "store refresh token: %v", err)
    }

    return &authv1.LoginResponse{
        AccessToken:  tokens.AccessToken,
        RefreshToken: tokens.RefreshToken,
        ExpiresAt:    tokens.AccessExpiry.Unix(),
    }, nil
}

func optionalString(val string) *string {
    if val == "" {
        return nil
    }
    v := val
    return &v
}

var timeNow = func() time.Time { return time.Now().UTC() }
