# Signs Downloader

CLI for downloading traffic sign images from the Adilet article and saving a manifest.

## Usage

```bash
go run ./cmd/signs_downloader --out data/signs
```

### Options

- `--url` page to scrape (default: `https://adilet.zan.kz/rus/docs/V2300033003`)
- `--out` output directory (default: `data/signs`)
- `--manifest` manifest JSON path (default: `<out>/manifest.json`)
- `--dry-run` list URLs without downloading
- `--timeout` HTTP timeout in seconds (default: `20`)

## Output

The command saves images into the output directory and writes a JSON manifest with file sizes and SHA-256 hashes.
