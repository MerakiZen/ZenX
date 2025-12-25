package graph

import "context"

type userContextKey struct{}

type UserContext struct {
	UserID string
}

func WithUserContext(ctx context.Context, info UserContext) context.Context {
	return context.WithValue(ctx, userContextKey{}, info)
}

func GetUserContext(ctx context.Context) (UserContext, bool) {
	val := ctx.Value(userContextKey{})
	if val == nil {
		return UserContext{}, false
	}
	info, ok := val.(UserContext)
	return info, ok
}
