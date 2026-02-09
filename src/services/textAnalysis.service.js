import {
  SENSATIONAL_WORDS,
  URGENT_PHRASES,
  EMOTIONAL_WORDS,
  FAKE_NEWS_INDICATORS,
  UNVERIFIED_PATTERNS,
  SCORING_RULES
} from "../utils/constants.js";

export function analyzeText(text) {
  // Handle empty or missing text
  if (!text || typeof text !== "string" || text.trim().length === 0) {
    return {
      riskLevel: "low",
      riskKeywordsFound: [],
      credibilityScore: 100,
      verdict: "Reliable"
    };
  }

  // Convert text to lowercase for analysis
  const lowerText = text.toLowerCase();

  // Detect sensational words
  const foundSensational = SENSATIONAL_WORDS.filter(word =>
    lowerText.includes(word.toLowerCase())
  );

  // Detect urgent phrases
  const foundUrgent = URGENT_PHRASES.filter(phrase =>
    lowerText.includes(phrase.toLowerCase())
  );

  // Detect emotional words
  const foundEmotional = EMOTIONAL_WORDS.filter(word =>
    lowerText.includes(word.toLowerCase())
  );

  // Detect fake news indicators (strongest signal)
  const foundFakeNews = FAKE_NEWS_INDICATORS.filter(indicator =>
    lowerText.includes(indicator.toLowerCase())
  );

  // Detect unverified claim patterns
  const foundUnverified = UNVERIFIED_PATTERNS.filter(pattern =>
    lowerText.includes(pattern.toLowerCase())
  );

  // Collect all found keywords for riskKeywordsFound array
  const riskKeywordsFound = [
    ...foundSensational,
    ...foundUrgent,
    ...foundEmotional,
    ...foundFakeNews,
    ...foundUnverified
  ];

  // Calculate credibility score starting from baseScore
  let credibilityScore = SCORING_RULES.baseScore;

  // Deduct penalties for each found item
  credibilityScore -= foundSensational.length * SCORING_RULES.sensationalPenalty;
  credibilityScore -= foundUrgent.length * SCORING_RULES.urgentPenalty;
  credibilityScore -= foundEmotional.length * SCORING_RULES.emotionalPenalty;
  credibilityScore -= foundFakeNews.length * SCORING_RULES.fakeNewsPenalty;
  credibilityScore -= foundUnverified.length * SCORING_RULES.unverifiedPenalty;

  // Additional penalty for multiple indicators (exponential decay)
  const totalIndicators = foundSensational.length + foundUrgent.length + 
                         foundEmotional.length + foundFakeNews.length + 
                         foundUnverified.length;
  if (totalIndicators > 3) {
    credibilityScore -= (totalIndicators - 3) * 5; // Extra penalty for multiple red flags
  }

  // Ensure score never goes below 0
  credibilityScore = Math.max(0, credibilityScore);

  // Generate verdict based on score (more strict thresholds)
  let verdict;
  if (credibilityScore >= 75) {
    verdict = "Reliable";
  } else if (credibilityScore >= 40) {
    verdict = "Questionable";
  } else {
    verdict = "High Risk";
  }

  // Determine risk level based on findings
  let riskLevel;
  const totalFindings = riskKeywordsFound.length;
  if (totalFindings === 0) {
    riskLevel = "low";
  } else if (totalFindings <= 3) {
    riskLevel = "medium";
  } else {
    riskLevel = "high";
  }

  // Override risk level if fake news indicators found
  if (foundFakeNews.length > 0) {
    riskLevel = "high";
    // Force verdict to High Risk if strong fake news indicators
    if (foundFakeNews.length >= 2 || credibilityScore < 50) {
      verdict = "High Risk";
    }
  }

  return {
    riskLevel,
    riskKeywordsFound,
    credibilityScore,
    verdict
  };
}

