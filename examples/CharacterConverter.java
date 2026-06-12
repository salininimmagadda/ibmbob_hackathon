package com.ibm.ace.encoding;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.nio.charset.CodingErrorAction;
import java.text.Normalizer;
import java.util.HashMap;
import java.util.Map;

/**
 * CharacterConverter - Handles character encoding conversion for ACE
 * 
 * Purpose: Convert characters that are not supported in CCSID 819 (ISO-8859-1)
 *          to their closest equivalents or replacement characters
 * 
 * Author: IBM Bob (AI Assistant)
 * Date: 2026-06-11
 * 
 * Usage in ESQL:
 *   CREATE FUNCTION callJavaConverter(IN inputText CHARACTER) 
 *       RETURNS CHARACTER
 *       LANGUAGE JAVA
 *       EXTERNAL NAME "com.ibm.ace.encoding.CharacterConverter.convert";
 */
public class CharacterConverter {
    
    // Character replacement map for common unsupported characters
    private static final Map<Character, Character> REPLACEMENT_MAP = new HashMap<>();
    
    static {
        // Smart quotes to regular quotes
        REPLACEMENT_MAP.put('\u201C', '"');  // Left double quotation mark
        REPLACEMENT_MAP.put('\u201D', '"');  // Right double quotation mark
        REPLACEMENT_MAP.put('\u2018', '\''); // Left single quotation mark
        REPLACEMENT_MAP.put('\u2019', '\''); // Right single quotation mark
        
        // Dashes to hyphens
        REPLACEMENT_MAP.put('\u2013', '-');  // En dash
        REPLACEMENT_MAP.put('\u2014', '-');  // Em dash
        
        // Ellipsis
        REPLACEMENT_MAP.put('\u2026', '.'); // Horizontal ellipsis
        
        // Bullet points
        REPLACEMENT_MAP.put('\u2022', '*');  // Bullet
        REPLACEMENT_MAP.put('\u2023', '*');  // Triangular bullet
        
        // Currency symbols (keep common ones, replace others)
        REPLACEMENT_MAP.put('\u20AC', 'E');  // Euro sign -> E
        REPLACEMENT_MAP.put('\u00A3', '#');  // Pound sign (actually supported in 819, but example)
        
        // Mathematical symbols
        REPLACEMENT_MAP.put('\u2264', '<');  // Less than or equal to
        REPLACEMENT_MAP.put('\u2265', '>');  // Greater than or equal to
        REPLACEMENT_MAP.put('\u2260', '!');  // Not equal to
        
        // Arrows
        REPLACEMENT_MAP.put('\u2190', '<');  // Leftwards arrow
        REPLACEMENT_MAP.put('\u2192', '>');  // Rightwards arrow
    }
    
    /**
     * Main conversion method - called from ESQL
     * 
     * @param inputText The text to convert
     * @return Converted text compatible with CCSID 819
     */
    public static String convert(String inputText) {
        return convertToISO88591(inputText);
    }
    
    /**
     * Convert text to ISO-8859-1 (CCSID 819) compatible format
     * 
     * @param inputText The text to convert
     * @return Converted text
     */
    public static String convertToISO88591(String inputText) {
        if (inputText == null || inputText.isEmpty()) {
            return inputText;
        }
        
        StringBuilder result = new StringBuilder(inputText.length());
        
        for (int i = 0; i < inputText.length(); i++) {
            char c = inputText.charAt(i);
            
            // Check if character is in valid ISO-8859-1 range (0-255)
            if (c <= 255) {
                result.append(c);
            } else {
                // Try to find replacement in map
                if (REPLACEMENT_MAP.containsKey(c)) {
                    result.append(REPLACEMENT_MAP.get(c));
                } else {
                    // Try Unicode normalization (decompose accented characters)
                    String normalized = normalizeCharacter(c);
                    if (normalized != null && normalized.length() > 0 && normalized.charAt(0) <= 255) {
                        result.append(normalized);
                    } else {
                        // Last resort: use replacement character or transliterate
                        String transliterated = transliterate(c);
                        result.append(transliterated);
                    }
                }
            }
        }
        
        return result.toString();
    }
    
    /**
     * Normalize a character using Unicode normalization
     * Decomposes accented characters into base + accent
     * 
     * @param c The character to normalize
     * @return Normalized string
     */
    private static String normalizeCharacter(char c) {
        String str = String.valueOf(c);
        String normalized = Normalizer.normalize(str, Normalizer.Form.NFD);
        
        // Remove combining diacritical marks (accents)
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < normalized.length(); i++) {
            char ch = normalized.charAt(i);
            if (ch <= 255) {
                result.append(ch);
            }
        }
        
        return result.toString();
    }
    
    /**
     * Transliterate character to ASCII equivalent
     * 
     * @param c The character to transliterate
     * @return Transliterated string
     */
    private static String transliterate(char c) {
        // Common transliterations
        switch (c) {
            // Greek letters
            case '\u03B1': return "alpha";
            case '\u03B2': return "beta";
            case '\u03B3': return "gamma";
            case '\u03B4': return "delta";
            
            // Chinese/Japanese/Korean - use placeholder
            case '\u4E00': case '\u9FFF': return "[CJK]";
            
            // Arabic - use placeholder
            case '\u0600': case '\u06FF': return "[AR]";
            
            // Cyrillic - transliterate common ones
            case '\u0410': return "A";  // Cyrillic A
            case '\u0411': return "B";  // Cyrillic B
            
            // Default: use question mark or Unicode escape
            default:
                // Return Unicode code point for debugging
                return String.format("[U+%04X]", (int) c);
        }
    }
    
    /**
     * Advanced conversion with charset encoder
     * Uses Java's built-in charset encoding with replacement
     * 
     * @param inputText The text to convert
     * @return Converted text
     */
    public static String convertWithEncoder(String inputText) {
        if (inputText == null || inputText.isEmpty()) {
            return inputText;
        }
        
        try {
            Charset iso88591 = Charset.forName("ISO-8859-1");
            CharsetEncoder encoder = iso88591.newEncoder();
            
            // Configure encoder to replace unmappable characters
            encoder.onMalformedInput(CodingErrorAction.REPLACE);
            encoder.onUnmappableCharacter(CodingErrorAction.REPLACE);
            encoder.replaceWith(new byte[] { '?' });
            
            // Encode and decode
            ByteBuffer encoded = encoder.encode(CharBuffer.wrap(inputText));
            return new String(encoded.array(), 0, encoded.limit(), iso88591);
            
        } catch (Exception e) {
            // Fallback to simple conversion
            return convertToISO88591(inputText);
        }
    }
    
    /**
     * Check if text contains characters not supported in ISO-8859-1
     * 
     * @param inputText The text to check
     * @return true if text contains unsupported characters
     */
    public static boolean hasUnsupportedCharacters(String inputText) {
        if (inputText == null || inputText.isEmpty()) {
            return false;
        }
        
        for (int i = 0; i < inputText.length(); i++) {
            char c = inputText.charAt(i);
            if (c > 255) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Get detailed information about unsupported characters
     * 
     * @param inputText The text to analyze
     * @return Array of unsupported character information
     */
    public static String[] getUnsupportedCharacterInfo(String inputText) {
        if (inputText == null || inputText.isEmpty()) {
            return new String[0];
        }
        
        StringBuilder info = new StringBuilder();
        int count = 0;
        
        for (int i = 0; i < inputText.length(); i++) {
            char c = inputText.charAt(i);
            if (c > 255) {
                info.append(String.format("Position %d: '%c' (U+%04X)%n", i, c, (int) c));
                count++;
            }
        }
        
        return new String[] {
            String.valueOf(count),
            info.toString()
        };
    }
    
    /**
     * Convert with detailed logging
     * Returns both converted text and conversion report
     * 
     * @param inputText The text to convert
     * @return Array: [0] = converted text, [1] = conversion report
     */
    public static String[] convertWithReport(String inputText) {
        if (inputText == null || inputText.isEmpty()) {
            return new String[] { inputText, "No conversion needed" };
        }
        
        StringBuilder result = new StringBuilder(inputText.length());
        StringBuilder report = new StringBuilder();
        int replacementCount = 0;
        
        for (int i = 0; i < inputText.length(); i++) {
            char c = inputText.charAt(i);
            
            if (c <= 255) {
                result.append(c);
            } else {
                replacementCount++;
                
                // Find replacement
                char replacement;
                if (REPLACEMENT_MAP.containsKey(c)) {
                    replacement = REPLACEMENT_MAP.get(c);
                    report.append(String.format("Pos %d: '%c' (U+%04X) -> '%c' (mapped)%n", 
                        i, c, (int) c, replacement));
                } else {
                    String normalized = normalizeCharacter(c);
                    if (normalized != null && normalized.length() > 0 && normalized.charAt(0) <= 255) {
                        replacement = normalized.charAt(0);
                        report.append(String.format("Pos %d: '%c' (U+%04X) -> '%c' (normalized)%n", 
                            i, c, (int) c, replacement));
                    } else {
                        replacement = '?';
                        report.append(String.format("Pos %d: '%c' (U+%04X) -> '?' (no mapping)%n", 
                            i, c, (int) c));
                    }
                }
                
                result.append(replacement);
            }
        }
        
        String summary = String.format("Converted %d characters out of %d total%n", 
            replacementCount, inputText.length());
        
        return new String[] {
            result.toString(),
            summary + report.toString()
        };
    }
    
    /**
     * Test method - can be called from ESQL for testing
     */
    public static String test() {
        String testInput = "Hello "World" – Testing… €100 ≥ £50";
        String converted = convertToISO88591(testInput);
        return String.format("Input: %s%nOutput: %s", testInput, converted);
    }
}

// Made with Bob
