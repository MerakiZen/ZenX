package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	notificationv1 "github.com/zenx/backend/proto/notification/v1"
	"github.com/zenx/backend/services/notification-service/internal/store"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// NotificationService implements notification.v1 RPCs.
type NotificationService struct {
	notificationv1.UnimplementedNotificationServiceServer
	repo *store.Repository
}

// New creates the service.
func New(repo *store.Repository) *NotificationService {
	return &NotificationService{repo: repo}
}

// EnqueueNotification creates a notification entry.
func (s *NotificationService) EnqueueNotification(ctx context.Context, req *notificationv1.EnqueueNotificationRequest) (*notificationv1.EnqueueNotificationResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	var scheduledFor *time.Time
	if req.GetScheduledFor() > 0 {
		t := time.Unix(req.GetScheduledFor(), 0).UTC()
		scheduledFor = &t
	}

	notificationID, err := s.repo.Enqueue(ctx, store.Notification{
		UserID:       userID,
		Template:     req.GetTemplate(),
		Payload:      req.GetData(),
		ScheduledFor: scheduledFor,
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "enqueue notification: %v", err)
	}

	return &notificationv1.EnqueueNotificationResponse{NotificationId: notificationID.String()}, nil
}

// UpdatePreference updates user preference per channel.
func (s *NotificationService) UpdatePreference(ctx context.Context, req *notificationv1.UpdatePreferenceRequest) (*notificationv1.Preference, error) {
	if req.GetPreference() == nil {
		return nil, status.Error(codes.InvalidArgument, "preference payload required")
	}

	userID, err := parseUUID(req.GetPreference().GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	pref, err := s.repo.UpsertPreference(ctx, store.Preference{
		UserID:  userID,
		Channel: req.GetPreference().GetChannel(),
		Enabled: req.GetPreference().GetEnabled(),
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "update preference: %v", err)
	}

	return toProtoPreference(pref), nil
}

// ListPreferences lists user notification preferences.
func (s *NotificationService) ListPreferences(ctx context.Context, req *notificationv1.ListPreferencesRequest) (*notificationv1.ListPreferencesResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	prefs, err := s.repo.ListPreferences(ctx, userID)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list preferences: %v", err)
	}

	resp := &notificationv1.ListPreferencesResponse{}
	for _, pref := range prefs {
		resp.Preferences = append(resp.Preferences, toProtoPreference(pref))
	}
	return resp, nil
}

// ListNotifications returns paginated notifications for a user.
func (s *NotificationService) ListNotifications(ctx context.Context, req *notificationv1.ListNotificationsRequest) (*notificationv1.ListNotificationsResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	cursor := ""
	limit := int32(20)
	if req.GetPagination() != nil {
		cursor = req.GetPagination().GetCursor()
		if req.GetPagination().GetLimit() > 0 {
			limit = req.GetPagination().GetLimit()
		}
	}

	notifications, nextCursor, err := s.repo.ListNotifications(ctx, userID, limit, cursor, req.GetStatus())
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list notifications: %v", err)
	}

	resp := &notificationv1.ListNotificationsResponse{NextCursor: nextCursor}
	for _, notif := range notifications {
		resp.Notifications = append(resp.Notifications, toProtoNotification(notif))
	}
	return resp, nil
}

// MarkNotificationRead updates the read state for a notification.
func (s *NotificationService) MarkNotificationRead(ctx context.Context, req *notificationv1.MarkNotificationReadRequest) (*notificationv1.Notification, error) {
	notifID, err := parseUUID(req.GetNotificationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	notif, err := s.repo.MarkNotificationRead(ctx, notifID, userID)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			return nil, status.Error(codes.NotFound, "notification not found")
		}
		return nil, status.Errorf(codes.Internal, "mark notification read: %v", err)
	}
	return toProtoNotification(notif), nil
}

func toProtoNotification(n store.Notification) *notificationv1.Notification {
	out := &notificationv1.Notification{
		Id:        n.ID.String(),
		UserId:    n.UserID.String(),
		Template:  n.Template,
		Data:      n.Payload,
		Status:    n.Status,
		CreatedAt: n.CreatedAt.Unix(),
	}
	if n.ScheduledFor != nil {
		out.ScheduledFor = n.ScheduledFor.Unix()
	}
	if n.SentAt != nil {
		out.SentAt = n.SentAt.Unix()
	}
	return out
}

func toProtoPreference(pref store.Preference) *notificationv1.Preference {
	return &notificationv1.Preference{
		UserId:  pref.UserID.String(),
		Channel: pref.Channel,
		Enabled: pref.Enabled,
	}
}

func parseUUID(val string) (uuid.UUID, error) {
	id, err := uuid.Parse(val)
	if err != nil {
		return uuid.Nil, err
	}
	return id, nil
}
