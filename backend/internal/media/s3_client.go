package media

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"alem-auto/config"
)

type S3Client struct {
	client *s3.Client
	bucket string
	cfg    config.S3Config
}

func NewS3Client(cfg config.S3Config) (*S3Client, error) {
	opts := []func(*awsconfig.LoadOptions) error{
		awsconfig.WithRegion(cfg.Region),
	}

	// Если указаны credentials, используем их
	if cfg.AccessKeyID != "" && cfg.SecretAccessKey != "" {
		opts = append(opts, awsconfig.WithCredentialsProvider(
			credentials.NewStaticCredentialsProvider(cfg.AccessKeyID, cfg.SecretAccessKey, ""),
		))
	}

	awsCfg, err := awsconfig.LoadDefaultConfig(context.Background(), opts...)
	if err != nil {
		return nil, fmt.Errorf("failed to load AWS config: %w", err)
	}

	// Если указан endpoint (для MinIO), настраиваем кастомный endpoint
	if cfg.Endpoint != "" {
		awsCfg.EndpointResolverWithOptions = aws.EndpointResolverWithOptionsFunc(
			func(service, region string, options ...interface{}) (aws.Endpoint, error) {
				return aws.Endpoint{
					URL:           cfg.Endpoint,
					SigningRegion: cfg.Region,
				}, nil
			},
		)
	}

	client := s3.NewFromConfig(awsCfg)

	return &S3Client{
		client: client,
		bucket: cfg.Bucket,
		cfg:    cfg,
	}, nil
}

// GeneratePresignedUploadURL генерирует pre-signed URL для загрузки файла
func (c *S3Client) GeneratePresignedUploadURL(ctx context.Context, objectKey string, contentType string, expiresIn time.Duration) (string, error) {
	presignClient := s3.NewPresignClient(c.client)

	request, err := presignClient.PresignPutObject(ctx, &s3.PutObjectInput{
		Bucket:      aws.String(c.bucket),
		Key:         aws.String(objectKey),
		ContentType: aws.String(contentType),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = expiresIn
	})
	if err != nil {
		return "", fmt.Errorf("failed to presign put object: %w", err)
	}

	return request.URL, nil
}

// GeneratePresignedDownloadURL генерирует pre-signed URL для скачивания файла
func (c *S3Client) GeneratePresignedDownloadURL(ctx context.Context, objectKey string, expiresIn time.Duration) (string, error) {
	presignClient := s3.NewPresignClient(c.client)

	request, err := presignClient.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(objectKey),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = expiresIn
	})
	if err != nil {
		return "", fmt.Errorf("failed to presign get object: %w", err)
	}

	return request.URL, nil
}

// DeleteObject удаляет объект из S3
func (c *S3Client) DeleteObject(ctx context.Context, objectKey string) error {
	_, err := c.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(objectKey),
	})
	if err != nil {
		return fmt.Errorf("failed to delete object: %w", err)
	}

	return nil
}

// GetObjectMetadata получает метаданные объекта
func (c *S3Client) GetObjectMetadata(ctx context.Context, objectKey string) (*s3.HeadObjectOutput, error) {
	output, err := c.client.HeadObject(ctx, &s3.HeadObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(objectKey),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to head object: %w", err)
	}

	return output, nil
}
