#!/bin/bash
AUDIO="$1"
TEXT="नमस्ते"
echo "$TEXT" | grep -q '[अ-ह]' && echo "hi" || echo "en"
