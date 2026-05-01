#!/bin/bash

# Quick script to create new articles or notes

# Check if title argument is provided
if [ -z "$1" ]; then
    echo "Usage: ./new-article.sh [article|note] 'Title Here'"
    echo ""
    echo "Examples:"
    echo "  ./new-article.sh article 'My First Post'"
    echo "  ./new-article.sh note 'Quick Thought'"
    exit 1
fi

CONTENT_TYPE=$1
TITLE=$2

# Validate content type
if [ "$CONTENT_TYPE" != "article" ] && [ "$CONTENT_TYPE" != "note" ]; then
    echo "❌ Error: Content type must be 'article' or 'note'"
    exit 1
fi

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo "❌ Hugo is not installed. Please run: brew install hugo"
    exit 1
fi

# Create content based on type
if [ "$CONTENT_TYPE" = "article" ]; then
    FILENAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -d '[:punct:]')
    hugo new articles/"${FILENAME}".md
    echo ""
    echo "✅ Article created: content/articles/${FILENAME}.md"
    echo "📝 Edit it with your content, then publish with:"
    echo "   git add content/articles/${FILENAME}.md"
    echo "   git commit -m 'Add article: ${TITLE}'"
    echo "   git push"
else
    FILENAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -d '[:punct:]')
    hugo new notes/"${FILENAME}".md
    echo ""
    echo "✅ Note created: content/notes/${FILENAME}.md"
    echo "📝 Edit it with your content, then publish with:"
    echo "   git add content/notes/${FILENAME}.md"
    echo "   git commit -m 'Add note: ${TITLE}'"
    echo "   git push"
fi
