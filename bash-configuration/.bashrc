function execute_script() {
  local -r full_script_file_path="example.sh"
  echo "full_script_file_path: ${full_script_file_path}"
  local -r script_file_path_without_directory_path="$(basename ${full_script_file_path})"
  echo "script_file_path_without_directory_path: ${script_file_path_without_directory_path}"
  local -r script_file_path_without_file_extension="${script_file_path_without_directory_path%.*}"
  echo "script_file_path_without_file_extension: ${script_file_path_without_file_extension}"

  time ./"${full_script_file_path=}" | tee "${script_file_path_without_file_extension}-$(date +%F-%T).txt"
}
