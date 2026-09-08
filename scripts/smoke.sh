#!/bin/sh
# end to end check against a running stack: login, then hit postgrest with the tokens
AUTH=${AUTH_URL:-http://localhost:4000}
API=${API_URL:-http://localhost:3000}
fail=0

login() {
  curl -s -X POST -H 'Content-Type: application/json' \
    -d "{\"email\":\"$1\",\"orgSlug\":\"$2\"}" "$AUTH/auth/login" \
    | sed -E 's/.*"token":"([^"]+)".*/\1/'
}

check() {
  if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1 (got: $2, want: $3)"; fail=1; fi
}

JULIA=$(login julia.brandt@nordwind-logistik.de nordwind)
WEBER=$(login m.weber@nordwind-logistik.de nordwind)
SARAH=$(login sarah@pixelhaus.io pixelhaus)

code=$(curl -s -o /dev/null -w '%{http_code}' "$API/note")
check 'no token is rejected' "$code" 401

other=$(curl -s -H "Authorization: Bearer $JULIA" "$API/note?select=org_id" | grep -c 2d236b56 || true)
check 'editor sees only own org notes' "$other" 0

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "Authorization: Bearer $JULIA" \
  -H 'Content-Type: application/json' -d '{"title":"smoke test","body":"temporary"}' "$API/note")
check 'editor can create a note' "$code" 201

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "Authorization: Bearer $JULIA" \
  -H 'Content-Type: application/json' -d '{"title":"sneaky","org_id":"2d236b56-2b32-4274-a9d1-2d29b5d818d7"}' "$API/note")
check 'editor cannot create in another org' "$code" 403

mine=$(curl -s -X POST -H "Authorization: Bearer $JULIA" -H 'Content-Type: application/json' -d '{}' \
  "$API/rpc/notes_for_me?select=author_id" | grep -vc 16e665ec | tr -d ' ')
check 'notes_for_me returns only own notes' "$mine" 0

code=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE -H "Authorization: Bearer $JULIA" "$API/note?title=eq.smoke%20test")
check 'editor cannot delete' "$code" 403

body=$(curl -s -X DELETE -H "Authorization: Bearer $WEBER" -H 'Prefer: return=representation' "$API/note?title=eq.smoke%20test&select=title")
check 'admin can delete in own org' "$body" '[{"title":"smoke test"}]'

body=$(curl -s -X DELETE -H "Authorization: Bearer $WEBER" -H 'Prefer: return=representation' "$API/note?title=eq.Font%20licence&select=title")
check 'admin cannot delete in another org' "$body" '[]'

count=$(curl -s -H "Authorization: Bearer $SARAH" "$API/note?select=title" | grep -o 'title' | wc -l | tr -d ' ')
check 'other org still has its notes' "$count" 2

exit $fail
