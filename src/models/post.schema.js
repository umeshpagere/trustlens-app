import { z } from "zod";

export const analyzePostSchema = z.object({
  text: z.string().min(5, "Text must be at least 5 characters"),
  imageUrl: z.string().url("Image URL must be a valid URL").optional()
});






