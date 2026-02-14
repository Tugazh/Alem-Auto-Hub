package signs

import "testing"

func TestExtractImageURLs(t *testing.T) {
	html := `
		<html>
			<body>
				<img src="https://adilet.zan.kz/files/1583/69/337.jpg" />
				<img src="https://adilet.zan.kz/files/1583/69/337.jpg" />
				<img src="https://adilet.zan.kz/files/1583/69/338.jpg" />
					<img src="/files/1583/69/339.jpg" />
					<img src="files/1583/69/340.jpg" />
				<img src="https://adilet.zan.kz/files/999/1/123.png" />
				<img src="https://example.com/ignore.jpg" />
			</body>
		</html>
	`

	urls := ExtractImageURLs(html)
	expected := []string{
		"https://adilet.zan.kz/files/1583/69/337.jpg",
		"https://adilet.zan.kz/files/1583/69/338.jpg",
		"https://adilet.zan.kz/files/1583/69/339.jpg",
		"https://adilet.zan.kz/files/1583/69/340.jpg",
		"https://adilet.zan.kz/files/999/1/123.png",
	}

	if len(urls) != len(expected) {
		t.Fatalf("expected %d urls, got %d", len(expected), len(urls))
	}

	for i, url := range expected {
		if urls[i] != url {
			t.Fatalf("expected url %q at index %d, got %q", url, i, urls[i])
		}
	}
}
