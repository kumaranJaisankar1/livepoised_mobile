import subprocess
import os

def refresh_git():
    cwd = 'd:/Apps/livePoised/livepoised_mobile'
    try:
        # Untrack everything (just from index, not disk)
        subprocess.run(['git', 'rm', '-r', '--cached', '.'], cwd=cwd, capture_output=True)
        # Add everything back (it will respect the new .gitignore)
        subprocess.run(['git', 'add', '.'], cwd=cwd, capture_output=True)
        # Get status
        result = subprocess.run(['git', 'status', '--short'], cwd=cwd, capture_output=True, text=True)
        with open(os.path.join(cwd, 'git_cleanup_result.txt'), 'w') as f:
            f.write(result.stdout)
        print("Done")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    refresh_git()
