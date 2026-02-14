package signs

import (
	"regexp"
	"strings"
)

var imageURLRegex = regexp.MustCompile(`(?i)(?:https?://adilet\.zan\.kz)?/?files/\d+/\d+/\d+\.(?:jpg|jpeg|png)`)

const defaultHostPrefix = "https://adilet.zan.kz/"

// ExtractImageURLs returns unique image URLs found in the supplied HTML in order of appearance.
func ExtractImageURLs(html string) []string {
	matches := imageURLRegex.FindAllString(html, -1)
	if len(matches) == 0 {
		return nil
	}

	seen := make(map[string]struct{}, len(matches))
	unique := make([]string, 0, len(matches))
	for _, match := range matches {
		normalized := normalizeURL(match)
		if _, exists := seen[normalized]; exists {
			continue
		}
		seen[normalized] = struct{}{}
		unique = append(unique, normalized)
	}
	return unique
}

func normalizeURL(raw string) string {
	if strings.HasPrefix(raw, "http://") || strings.HasPrefix(raw, "https://") {
		return raw
	}

	trimmed := strings.TrimPrefix(raw, "/")
	return defaultHostPrefix + trimmed
}
