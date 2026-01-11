#!/usr/bin/bash
KEYS="$(
	cat ~/Downloads/foo.txt |
		jq -r 'keys|.[]' |
		cut -d/ -f6- |
		sort |
		uniq |
		grep /
)"
mkdir -p data
for key in $(echo "$KEYS"); do
	echo "Processing $key"
	file="data/$(echo "$key" | cut -d/ -f2- | sed 's/[-]/_/g').tsv"
	data="$(
		(
			cat ~/Downloads/foo.txt |
			jq -r 'to_entries|map(select(.key|match("/'"$key"'$";"")))|map(select(.value|match(".\n.";"")))|.[].value|.|=sub("^.*\n";"")'
		) |
			sed -E 's|([0-9]{2})/([0-9]{2})/([0-9]{4})|\3-\1-\2|g' |
			cut -d$'\t' -f1,3-
	)"
	metadata="$(
		(
			cat ~/Downloads/foo.txt |
			jq -r 'to_entries|map(select(.key|match("/'"$key"'$";"")))|.[1].value|match("^(.*)").captures[0].string'
		) |
			sed -E 's|([0-9]{2})/([0-9]{2})/([0-9]{4})|\3-\1-\2|g'
	)"
	(
		echo -e "Stock\t$metadata" |
			tr '[:upper:]' '[:lower:]' |
			sed -E 's|/|_per_|g' |
			sed -E 's/[ _&%-]+/_/g' |
			sed -E 's/(\t|^)_/\1/g' |
			sed -E 's/_(\t|$)/\1/g'
		echo "$data" |
			sed -E 's/%$//' |
			sed -E 's/\t-$/\t/' |
			sed -E 's/([0-9]),([0-9])/\1\2/g' |
			sed -E 's#(^|\t)(N/A|-)(\t|$)#\1\3#g' |
			tr -d '$'
	) |
		gawk '
		function abs(x) { return x < 0 ? -x : x }
		function round(x) { return int(x + 0.5 * (x < 0 ? -1 : 1)) }
		{
			for (i = 1; i <= NF; ++i) {
				match($i, /(\t|^)(-?[0-9.]+)([A-Z])(\t|$)/,a)
				if (a[3] == "K") { j = 1 }
				else if (a[3] == "M") { j = 2 }
				else if (a[3] == "B") { j = 3 }
				else if (a[3] == "T") { j = 4 }
				else { j = 0 }
				if (j == 0) {
					f="%s"
				} else {
					places = (5 - int(log(abs(a[2]) * (1000 ** j)) / log(10)))
					$i = a[2] * (1000 ** j)
					if (place <= 0) {
						f = "%d"
						$i = round($i)
					} else {
						f = "%."places"f"
					}
				}
				if (i > 1) {
					printf "\t"
				}
				printf f, $i
			}
			print ""
		}' |
		sed -E 's/\.0+(\t|$)/\1/g' > "$file"
done
