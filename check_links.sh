#!/bin/bash

echo "Checking links in bib.html..."
echo "=============================="

failed_links=()
redirect_links=()
success_count=0
total_count=0

while IFS= read -r url; do
    total_count=$((total_count + 1))
    echo -n "Checking: $url ... "
    
    # Get HTTP status code
    status_code=$(curl -I -s -o /dev/null -w "%{http_code}" "$url" --connect-timeout 10 --max-time 15)
    
    case $status_code in
        200)
            echo "✅ OK"
            success_count=$((success_count + 1))
            ;;
        301|302|303|307|308)
            echo "🔄 REDIRECT ($status_code)"
            redirect_links+=("$url -> $status_code")
            success_count=$((success_count + 1))
            ;;
        000)
            echo "❌ TIMEOUT/CONNECTION ERROR"
            failed_links+=("$url -> TIMEOUT")
            ;;
        *)
            echo "❌ ERROR ($status_code)"
            failed_links+=("$url -> $status_code")
            ;;
    esac
    
    # Small delay to be nice to servers
    sleep 0.5
done < links_to_check.txt

echo ""
echo "SUMMARY:"
echo "========"
echo "Total links checked: $total_count"
echo "Successful: $success_count"
echo "Failed: ${#failed_links[@]}"
echo "Redirects: ${#redirect_links[@]}"

if [ ${#failed_links[@]} -gt 0 ]; then
    echo ""
    echo "FAILED LINKS:"
    echo "============"
    for link in "${failed_links[@]}"; do
        echo "$link"
    done
fi

if [ ${#redirect_links[@]} -gt 0 ]; then
    echo ""
    echo "REDIRECT LINKS:"
    echo "=============="
    for link in "${redirect_links[@]}"; do
        echo "$link"
    done
fi
