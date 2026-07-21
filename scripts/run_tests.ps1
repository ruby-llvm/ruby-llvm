# powershell -ExecutionPolicy Bypass -File .\scripts\run_tests.ps1 -Runs 20
param([int]$Runs = 10)

$loader = "C:/ruby-mswin/lib/ruby/gems/4.1.0+4/gems/rake-13.4.2/lib/rake/rake_test_loader.rb"
$tests = (Get-ChildItem test/*_test.rb | ForEach-Object { "test/$($_.Name)" })

$crashes = 0
$codes = @()
for ($i = 1; $i -le $Runs; $i++) {
  bundle exec ruby -w -I"test" $loader @tests *>$null
  $code = $LASTEXITCODE
  $codes += $code
  if ($code -ne 0) { $crashes++ }
  Write-Host ("run {0}/{1}: exit={2}" -f $i, $Runs, $code)
}

$summary = ($codes | ForEach-Object { "$_" }) -join " "
Write-Host ("crashes={0}/{1}  codes=[{2}]" -f $crashes, $Runs, $summary)
