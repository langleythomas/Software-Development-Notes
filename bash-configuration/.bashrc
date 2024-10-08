export PATH="$PATH:/opt/nvim/"

function execute_script() {
  local -r full_script_file_path="${1}"
  local -r script_file_path_without_directory_path="$(basename ${full_script_file_path})"
  local -r script_file_path_without_file_extension="${script_file_path_without_directory_path%.*}"

  time ./"${full_script_file_path=}" | tee "${script_file_path_without_file_extension}-$(date +%F-%T).txt"
}

alias rm="rm -i --verbose"
