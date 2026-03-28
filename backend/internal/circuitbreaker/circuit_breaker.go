package circuitbreaker

import (
	"log/slog"
	"time"

	"github.com/sony/gobreaker"
)

// CircuitBreakerConfig holds circuit breaker configuration
type CircuitBreakerConfig struct {
	MaxRequests      uint32        // Max requests allowed to pass in HalfOpen state
	Interval         time.Duration // Interval to calculate failure rate
	Timeout          time.Duration // Timeout after which circuit becomes HalfOpen
	FailureRate      float64       // Failure rate threshold (0.0 - 1.0)
	MinRequests      uint32        // Minimum requests before checking failure rate
	ConsecutiveFails uint32        // Consecutive failures to trip circuit
}

// DefaultConfig returns sensible default configuration
func DefaultConfig() CircuitBreakerConfig {
	return CircuitBreakerConfig{
		MaxRequests:      10,
		Interval:         10 * time.Second,
		Timeout:          30 * time.Second,
		FailureRate:      0.5, // 50% failure rate
		MinRequests:      5,
		ConsecutiveFails: 3,
	}
}

// NewCircuitBreaker creates a new circuit breaker with the given config
func NewCircuitBreaker(name string, config CircuitBreakerConfig) *gobreaker.CircuitBreaker {
	settings := gobreaker.Settings{
		Name:        name,
		MaxRequests: config.MaxRequests,
		Interval:    config.Interval,
		Timeout:     config.Timeout,
		ReadyToTrip: func(counts gobreaker.Counts) bool {
			// Trip if consecutive failures exceed threshold
			if counts.ConsecutiveFailures >= config.ConsecutiveFails {
				slog.Warn("Circuit breaker tripping",
					"name", name,
					"consecutive_failures", counts.ConsecutiveFailures,
					"reason", "consecutive_failures",
				)
				return true
			}

			// Trip if failure rate exceeds threshold
			if counts.Requests >= config.MinRequests {
				failureRate := float64(counts.TotalFailures) / float64(counts.Requests)
				if failureRate >= config.FailureRate {
					slog.Warn("Circuit breaker tripping",
						"name", name,
						"failure_rate", failureRate,
						"total_failures", counts.TotalFailures,
						"total_requests", counts.Requests,
						"reason", "failure_rate",
					)
					return true
				}
			}

			return false
		},
		OnStateChange: func(name string, from gobreaker.State, to gobreaker.State) {
			slog.Info("Circuit breaker state change",
				"name", name,
				"from", from.String(),
				"to", to.String(),
			)
		},
		IsSuccessful: func(err error) bool {
			// Consider request successful if no error
			return err == nil
		},
	}

	return gobreaker.NewCircuitBreaker(settings)
}

// Execute wraps a function call with circuit breaker protection
func Execute(cb *gobreaker.CircuitBreaker, fn func() (interface{}, error)) (interface{}, error) {
	return cb.Execute(fn)
}

// ExecuteWithContext wraps a context-aware function call
func ExecuteWithContext(cb *gobreaker.CircuitBreaker, fn func() (interface{}, error)) (interface{}, error) {
	result, err := cb.Execute(fn)

	if err == gobreaker.ErrOpenState {
		slog.Warn("Circuit breaker is open, rejecting request",
			"name", cb.Name(),
			"state", cb.State().String(),
		)
	}

	return result, err
}

// GetState returns the current state of the circuit breaker
func GetState(cb *gobreaker.CircuitBreaker) gobreaker.State {
	return cb.State()
}

// GetCounts returns current circuit breaker counts
func GetCounts(cb *gobreaker.CircuitBreaker) gobreaker.Counts {
	return cb.Counts()
}
