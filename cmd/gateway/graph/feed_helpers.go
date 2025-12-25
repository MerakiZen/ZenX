package graph

import (
	"context"

	"github.com/zenx/backend/cmd/gateway/graph/model"
	workoutv1 "github.com/zenx/backend/proto/workout/v1"
)

func (r *queryResolver) feedConnection(ctx context.Context, limit *int, cursor *string, discover bool) (*model.FeedConnection, error) {
	uc, ok := GetUserContext(ctx)
	if !ok {
		// Return empty feed for unauthenticated users instead of error
		return &model.FeedConnection{
			Edges: []*model.FeedPost{},
		}, nil
	}

	req := &workoutv1.ListFeedPostsRequest{
		UserId:     uc.UserID,
		Discover:   discover,
		Pagination: buildPagination(limit, cursor),
	}
	resp, err := r.WorkoutClient.ListFeedPosts(ctx, req)
	if err != nil {
		return nil, err
	}

	userIDs := make([]string, 0, len(resp.GetPosts()))
	for _, post := range resp.GetPosts() {
		userIDs = append(userIDs, post.GetUserId())
	}
	profiles, err := r.fetchProfiles(ctx, userIDs)
	if err != nil {
		return nil, err
	}

	connection := &model.FeedConnection{}
	for _, post := range resp.GetPosts() {
		connection.Edges = append(connection.Edges, convertFeedPost(post, profiles[post.GetUserId()]))
	}
	if resp.GetNextCursor() != "" {
		connection.NextCursor = nullableString(resp.GetNextCursor())
	}
	return connection, nil
}
