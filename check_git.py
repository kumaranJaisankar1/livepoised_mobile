import subprocess
import os

def run_git_status():
    try:
        result = subprocess.run(['git', 'status', '--short'], capture_output=True, text=True, cwd='d:/Apps/livePoised/livepoised_mobile')
        with open('d:/Apps/livePoised/livepoised_mobile/git_status_debug.txt', 'w') as f:
            f.write(result.stdout)
            f.write("\n--- ERRORS ---\n")
            f.write(result.stderr)
        print("Success")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    run_git_status()
