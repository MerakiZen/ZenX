package token

import (
    "errors"
    "time"

    "github.com/golang-jwt/jwt/v5"
)

// Manager handles JWT creation and validation.
type Manager struct {
    accessSecret  []byte
    refreshSecret []byte
    accessTTL     time.Duration
    refreshTTL    time.Duration
}

// NewManager constructs a token manager.
func NewManager(accessSecret, refreshSecret string, accessTTL, refreshTTL time.Duration) *Manager {
    return &Manager{
        accessSecret:  []byte(accessSecret),
        refreshSecret: []byte(refreshSecret),
        accessTTL:     accessTTL,
        refreshTTL:    refreshTTL,
    }
}

// Tokens represents the generated JWT pair.
type Tokens struct {
    AccessToken  string
    RefreshToken string
    AccessExpiry time.Time
    RefreshExpiry time.Time
}

// CreateTokens returns signed tokens for a user.
func (m *Manager) CreateTokens(userID string) (Tokens, error) {
    now := time.Now().UTC()
    accessExp := now.Add(m.accessTTL)
    refreshExp := now.Add(m.refreshTTL)

    access := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
        "sub":  userID,
        "typ": "access",
        "exp": accessExp.Unix(),
        "iat": now.Unix(),
    })

    refresh := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
        "sub":  userID,
        "typ": "refresh",
        "exp": refreshExp.Unix(),
        "iat": now.Unix(),
    })

    accessToken, err := access.SignedString(m.accessSecret)
    if err != nil {
        return Tokens{}, err
    }

    refreshToken, err := refresh.SignedString(m.refreshSecret)
    if err != nil {
        return Tokens{}, err
    }

    return Tokens{
        AccessToken:  accessToken,
        RefreshToken: refreshToken,
        AccessExpiry: accessExp,
        RefreshExpiry: refreshExp,
    }, nil
}

// ValidateAccessToken parses and validates an access token.
func (m *Manager) ValidateAccessToken(token string) (jwt.MapClaims, error) {
    parsed, err := jwt.Parse(token, func(t *jwt.Token) (interface{}, error) {
        if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, errors.New("unexpected signing method")
        }
        return m.accessSecret, nil
    })
    if err != nil {
        return nil, err
    }

    claims, ok := parsed.Claims.(jwt.MapClaims)
    if !ok || !parsed.Valid {
        return nil, errors.New("invalid token")
    }

    if claims["typ"] != "access" {
        return nil, errors.New("unexpected token type")
    }

    return claims, nil
}

// ValidateRefreshToken validates the refresh JWT.
func (m *Manager) ValidateRefreshToken(token string) (jwt.MapClaims, error) {
    parsed, err := jwt.Parse(token, func(t *jwt.Token) (interface{}, error) {
        if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, errors.New("unexpected signing method")
        }
        return m.refreshSecret, nil
    })
    if err != nil {
        return nil, err
    }

    claims, ok := parsed.Claims.(jwt.MapClaims)
    if !ok || !parsed.Valid {
        return nil, errors.New("invalid token")
    }

    if claims["typ"] != "refresh" {
        return nil, errors.New("unexpected token type")
    }

    return claims, nil
}
