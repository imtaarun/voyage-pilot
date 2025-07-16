import axios from 'axios';
import config from '../config/defaults';
/**
 * Sends a prompt to Gemini and returns the response.
 * @param promptText The text prompt to send.
 */
export async function fetchGeminiData(promptText: string): Promise<string> {
  try {
    const response = await axios.post(
      `${config.GEMINI_API_URL}?key=${config.GEMINI_API_KEY}`,
      {
        contents: [
          {
            parts: [
              { text: promptText }
            ]
          }
        ]
      },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );
    // Adjust this according to Gemini's actual response structure
    return response.data.candidates?.[0]?.content?.parts?.[0]?.text || '';
  } catch (error: any) {
    console.error('Error fetching data from Gemini:', error.message);
    throw new Error('Failed to fetch data from Gemini');
  }
}