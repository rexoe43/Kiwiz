
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY") || "";
const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";

const MODEL = "llama-3.1-8b-instant";

const GROQ_HEADERS = {
  "Authorization": `Bearer ${GROQ_API_KEY}`,
  "Content-Type": "application/json",
};

interface Message {
  role: "user" | "assistant";
  content: string;
}


const SYSTEM_PROMPT = `Eres Kiwiz, un asistente de estudio inteligente y amigable. 
Tu objetivo es ayudar a los estudiantes con sus dudas académicas de manera clara, 
didáctica y precisa.

Características de tu personalidad:
- Eres paciente y explicas conceptos complejos de forma sencilla
- Usas ejemplos prácticos para ilustrar tus explicaciones
- Fomentas el pensamiento crítico haciendo preguntas guía
- Te adaptas al nivel de conocimiento del estudiante
- Si no sabes algo, lo admites honestamente y ofreces buscar información

Reglas importantes:
1. Responde ÚNICAMENTE en español
2. Tus respuestas deben ser educativas y constructivas
3. No inventes información; si no estás seguro, sugiere fuentes confiables
4. Mantén un tono cálido y motivador
5. Ofrece seguimiento con preguntas para profundizar el tema

Estructura recomendada para tus respuestas:
1. Saludo o reconocimiento de la pregunta
2. Explicación clara y estructurada
3. Ejemplo o analogía (si aplica)
4. Pregunta de seguimiento para fomentar la reflexión`;


serve(async (req) => {
  try {
    // 1. Validar método
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Método no permitido" }), {
        status: 405,
        headers: { "Content-Type": "application/json" },
      });
    }

    
    const { message, history } = await req.json();

    if (!message || typeof message !== "string") {
      return new Response(JSON.stringify({ error: "Mensaje inválido" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    
    const messages: Message[] = [
      { role: "system", content: SYSTEM_PROMPT },
      ...(history || []).filter((m: Message) => 
        m.role === "user" || m.role === "assistant"
      ),
    ];

    
    const response = await fetch(GROQ_API_URL, {
      method: "POST",
      headers: GROQ_HEADERS,
      body: JSON.stringify({
        model: MODEL,
        messages: messages,
        temperature: 0.7,
        max_tokens: 1024,
        top_p: 0.9,
        stream: false,
      }),
    });

    
    if (!response.ok) {
      const errorData = await response.text();
      console.error("Error en Groq API:", errorData);
      
      return new Response(
        JSON.stringify({
          error: "Error al procesar la consulta con la IA",
          details: errorData,
        }),
        {
          status: response.status,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const data = await response.json();
    const aiResponse = data.choices?.[0]?.message?.content || "";

    if (!aiResponse) {
      return new Response(
        JSON.stringify({ error: "La IA no generó una respuesta" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    
    return new Response(
      JSON.stringify({
        response: aiResponse,
        usage: data.usage, 
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (error) {
    console.error("Error en Edge Function:", error);
    
    return new Response(
      JSON.stringify({
        error: "Error interno del servidor",
        details: error.message,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});