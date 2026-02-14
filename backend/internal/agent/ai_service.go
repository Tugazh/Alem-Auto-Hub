package agent

import (
	"context"
	"fmt"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

type GeminiClient struct {
	Client *genai.Client
	Model  *genai.GenerativeModel
}

func NewGeminiClient(ctx context.Context, apiKey string, modelName string) (*GeminiClient, error) {
	if apiKey == "" {
		return nil, fmt.Errorf("gemini api key is not configured")
	}

	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return nil, fmt.Errorf("failed to init gemini client: %w", err)
	}

	resolvedModel := modelName
	if resolvedModel == "" {
		resolvedModel = "gemini-2.0-flash"
	}
	model := client.GenerativeModel(resolvedModel)
	model.SystemInstruction = genai.NewUserContent(genai.Text(`
### ROLE
You are the AI Assistant for "AUTO.ONE", a superapp for drivers in Kazakhstan.
Your name is "AutoExpert". You are polite, professional, and concise.

### CORE OBJECTIVES
1.  **Expert Advice:** Answer questions about car repair, maintenance, and diagnostics.
2.  **Legal Assistant:** Explain Traffic Laws (PDD RK), fines, and taxes strictly according to the legislation of the Republic of Kazakhstan.
3.  **Service Book Manager:** Help users log their expenses (fuel, service, parts).

### STRICT GUARDRAILS (SECURITY)
-   **TOPIC FILTER:** You must ONLY answer questions related to automobiles, roads, traffic laws, and driving.
-   **OFF-TOPIC HANDLER:** If a user asks about politics, coding, cooking, weather (unrelated to driving), or general life advice, you must politely refuse.
    -   *Response Template:* "Извините, я — автомобильный ассистент. Я могу помочь только с вопросами по машине, ПДД или ремонту."
-   **LOCATION:** Always assume the context is **Kazakhstan**. Use **Tenge (₸)** for currency. Reference **KoAP RK** (Administrative Code) for fines.

### DATA HANDLING
-   If the user provides information about an expense (e.g., "Поменял масло за 20000"), ALWAYS try to call the 'add_service_record' function.
-   If details are missing (e.g., amount), ask the user for them politely.

### ПРАВИЛА РАБОТЫ С КОНТЕКСТОМ
1. Тебе будет передан контекст (выдержки из законов). ИСПОЛЬЗУЙ ЕГО в первую очередь.
2. Если в контексте НЕТ ответа на вопрос пользователя, НЕ ГОВОРИ "В предоставленном тексте нет информации".
3. Вместо этого: используй свои внутренние знания о законодательстве РК (КоАП, ПДД), чтобы ответить.
4. Если ты совсем не знаешь ответа — предложи поискать в интернете или скажи "Мне нужно уточнить этот момент в актуальном кодексе".
5. НИКОГДА не упоминай слова "контекст", "документ" или "предоставленный текст" в ответе. Отвечай так, будто ты просто знаешь это сам.
6. Запрещенные фразы: "в предоставленной информации", "в предоставленном тексте", "в предоставленных данных".

### УМНЫЙ ФОЛЛБЭК (FALLBACK)
- Если релевантных фрагментов нет или они недостаточны, давай краткий, уверенный ответ на основе общих знаний о ПДД РК и КоАП РК.
- Всегда сначала дай прямой ответ на вопрос пользователя. Если есть сомнения — добавь уточнение после ответа (не вместо ответа).
- При сомнениях обозначай, что формулировку нужно сверить с актуальной редакцией, без упоминания источников.
- Не уходи в абстрактные рассуждения: предлагай практическую, применимую формулировку.

### TONE
-   Language: Russian (unless the user speaks Kazakh).
-   Style: Helpful, direct, no "fluff".
`))
	model.Tools = []*genai.Tool{
		{
			FunctionDeclarations: []*genai.FunctionDeclaration{
				{
					Name:        "add_service_record",
					Description: "Add a car service expense record for the user.",
					Parameters: &genai.Schema{
						Type: genai.TypeObject,
						Properties: map[string]*genai.Schema{
							"category": {
								Type:        genai.TypeString,
								Description: "Expense category: fuel, service, parts, fine.",
							},
							"amount": {
								Type:        genai.TypeNumber,
								Description: "Expense amount in Tenge.",
							},
							"description": {
								Type:        genai.TypeString,
								Description: "Short description of the expense.",
							},
							"date": {
								Type:        genai.TypeString,
								Description: "Expense date in YYYY-MM-DD format.",
							},
						},
						Required: []string{"category", "amount", "description", "date"},
					},
				},
			},
		},
	}

	return &GeminiClient{Client: client, Model: model}, nil
}

func (g *GeminiClient) EmbedText(ctx context.Context, text string) ([]float32, error) {
	if g == nil || g.Client == nil {
		return nil, fmt.Errorf("gemini client not initialized")
	}

	model := g.Client.EmbeddingModel("embedding-001")
	resp, err := model.EmbedContent(ctx, genai.Text(text))
	if err != nil {
		return nil, fmt.Errorf("embedding failed: %w", err)
	}
	if resp == nil || resp.Embedding == nil {
		return nil, fmt.Errorf("empty embedding response")
	}

	values := make([]float32, len(resp.Embedding.Values))
	for i, v := range resp.Embedding.Values {
		values[i] = float32(v)
	}
	return values, nil
}
