// Sensational words that indicate clickbait or exaggerated content
export const SENSATIONAL_WORDS = [
  "breaking",
  "shocking",
  "viral",
  "unbelievable",
  "exclusive",
  "amazing",
  "incredible",
  "outrageous",
  "explosive",
  "devastating",
  "stunning",
  "mind-blowing",
  "you won't believe",
  "doctors hate",
  "this one trick",
  "secret",
  "hidden",
  "exposed",
  "revealed",
  "leaked"
];

// Urgent phrases that create false urgency
export const URGENT_PHRASES = [
  "act now",
  "share immediately",
  "before it's deleted",
  "limited time",
  "urgent",
  "breaking news",
  "just in",
  "you must see",
  "watch before removed",
  "share this now",
  "spread the word",
  "tell everyone",
  "forward this",
  "don't ignore",
  "this will shock you"
];

// Emotional words that manipulate feelings
export const EMOTIONAL_WORDS = [
  "fear",
  "anger",
  "hate",
  "miracle",
  "disaster",
  "terrifying",
  "horrifying",
  "outrage",
  "scandal",
  "conspiracy",
  "cover-up",
  "lies",
  "fraud",
  "corruption",
  "betrayal",
  "warning",
  "alert",
  "danger",
  "threat",
  "emergency"
];

// Fake news indicators - common patterns in misinformation
export const FAKE_NEWS_INDICATORS = [
  "fake news",
  "alternative facts",
  "they don't want you to know",
  "mainstream media won't tell you",
  "the truth they're hiding",
  "government cover-up",
  "big pharma",
  "big tech",
  "deep state",
  "illuminati",
  "one simple trick",
  "doctors are shocked",
  "scientists baffled",
  "nobody is talking about",
  "media silent",
  "censored",
  "banned",
  "suppressed",
  "they're lying",
  "don't trust",
  "wake up",
  "sheeple",
  "wake up people"
];

// Unverified claim patterns
export const UNVERIFIED_PATTERNS = [
  "sources say",
  "according to insiders",
  "unnamed sources",
  "anonymous tip",
  "rumors suggest",
  "allegedly",
  "reportedly",
  "supposedly",
  "claims",
  "purportedly",
  "unconfirmed reports",
  "unverified",
  "unsubstantiated"
];

// Scoring rules for credibility analysis
export const SCORING_RULES = {
  baseScore: 100,
  sensationalPenalty: 8,
  urgentPenalty: 12,
  emotionalPenalty: 6,
  fakeNewsPenalty: 20,  // Higher penalty for fake news indicators
  unverifiedPenalty: 15  // Penalty for unverified claims
};






