package knowledge

import "github.com/pgvector/pgvector-go"

func ToVector(values []float32) pgvector.Vector {
	return pgvector.NewVector(values)
}
