for /r %%f in (*.csv) do (
	if "%%~xf"==".csv" iconv --from-code=UTF-16LE --to-code=CP1250 -c "%%f" > "%%fx"
)

rm *.csv