# powershell -ExecutionPolicy Bypass -File .\scripts\find_crash.ps1
$tests = @(
  "test/array_test.rb"
  "test/attribute_test.rb"
  "test/basic_block_test.rb"
  "test/binary_operations_test.rb"
  "test/bitcode_test.rb"
  "test/branch_test.rb"
  "test/builder_gep_test.rb"
  "test/builder_test.rb"
  "test/call_test.rb"
  "test/comparisons_test.rb"
  "test/conversions_test.rb"
  "test/double_test.rb"
  "test/equality_test.rb"
  "test/ffi_test.rb"
  "test/function_test.rb"
  "test/generic_value_test.rb"
  "test/instruction_test.rb"
  "test/integer_test.rb"
  "test/ipo_test.rb"
  "test/linker_test.rb"
  "test/lljit_test.rb"
  "test/mcjit_test.rb"
  "test/memory_access_test.rb"
  "test/module_test.rb"
  "test/parameter_collection_test.rb"
  "test/pass_builder_test.rb"
  "test/pass_manager_builder_test.rb"
  "test/phi_test.rb"
  "test/select_test.rb"
  "test/struct_test.rb"
  "test/target_test.rb"
  "test/type_test.rb"
  "test/value_test.rb"
  "test/vector_test.rb"
)

$loader = "C:/ruby-mswin/lib/ruby/gems/4.1.0+4/gems/rake-13.4.2/lib/rake/rake_test_loader.rb"
$runs = 10

foreach ($test in $tests) {
  $crashes = 0
  $codes = @()
  for ($i = 1; $i -le $runs; $i++) {
    bundle exec ruby -w -I"test" $loader $test *>$null
    $code = $LASTEXITCODE
    $codes += $code
    if ($code -ne 0) { $crashes++ }
  }
  $summary = ($codes | ForEach-Object { "$_" }) -join " "
  Write-Host ("{0,-45} crashes={1}/{2}  codes=[{3}]" -f $test, $crashes, $runs, $summary)
}
