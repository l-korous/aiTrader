for /r %%v in (*.csv) do iconv --from-code=UTF-16LE --to-code=CP1250 -c "%%v" > "%%vx"

rm *.csv