# pip install beautifulsoup4
import os
from bs4 import BeautifulSoup

def extract_red_lines(html_path):
    """
    Extract lines that contain <span class='red'>, indicating uncovered code in the HTML report.
    """
    with open(html_path, encoding="utf-8") as f:
        soup = BeautifulSoup(f, "html.parser")

    uncovered_lines = set()

    # Find all <tr> rows
    rows = soup.find_all("tr")
    for row in rows:
        tds = row.find_all("td")
        if len(tds) != 3:
            continue

        line_td = tds[0]
        coverage_td = tds[1]  # This is where the coverage status (uncovered) is noted

        # Extract line number
        try:
            line_number = int(line_td.text.strip())
        except ValueError:
            continue

        # Check if the line contains the <span class='red'> element (uncovered)
        code_td = tds[2]
        if code_td.find("span", class_="red"):
            uncovered_lines.add(line_number)

    return uncovered_lines

def compare_reports_with_multiple_files(file_paths_with_seed, file_paths_no_seed, output_file):
    """
    Compare coverage for a bunch of HTML files, outputting the differences in coverage to an output file.
    """
    # Open the output file for writing
    with open(output_file, 'w', encoding="utf-8") as out_f:
        # Process each pair of files
        for file_with_seed, file_no_seed in zip(file_paths_with_seed, file_paths_no_seed):
            print(f"Processing {file_with_seed} and {file_no_seed}...")
            
            # Extract uncovered lines from both files
            with_seed = extract_red_lines(file_with_seed)
            no_seed = extract_red_lines(file_no_seed)

            if not with_seed and not no_seed:
                continue  # Don't write anything for this file
            
            # Find differences
            only_with_seed = with_seed - no_seed
            only_without_seed = no_seed - with_seed

            if not (only_with_seed or only_without_seed):
                continue  # No meaningful diff

            # Write results to the output file
            out_f.write(f"Comparing: {file_with_seed} and {file_no_seed}\n")
            out_f.write("-" * 60 + "\n")
            
            out_f.write("Uncovered lines only with seed:\n")
            if only_with_seed:
                for line in sorted(only_with_seed):
                    out_f.write(f"  Line {line}\n")
            else:
                out_f.write("  None\n")
                
            out_f.write("\nUncovered lines only without seed:\n")
            if only_without_seed:
                for line in sorted(only_without_seed):
                    out_f.write(f"  Line {line}\n")
            else:
                out_f.write("  None\n")
            
            out_f.write("\n" + "=" * 60 + "\n\n")


def get_file_pairs(seed_root, no_seed_root, suffix=".c.html"):
    file_paths_with_seed = []
    file_paths_no_seed = []

    for root, _, files in os.walk(seed_root):
        for file in files:
            if file.endswith(suffix):
                # Full path for the "with seed" version
                full_seed_path = os.path.join(root, file)
                
                # Relative path from the seed root
                rel_path = os.path.relpath(full_seed_path, seed_root)

                # Corresponding path in the "no seed" directory
                full_no_seed_path = os.path.join(no_seed_root, rel_path)

                # Check if the corresponding no-seed file exists
                if os.path.exists(full_no_seed_path):
                    file_paths_with_seed.append(full_seed_path)
                    file_paths_no_seed.append(full_no_seed_path)
                else:
                    print(f"⚠️ Missing in no-seed: {full_no_seed_path}")

    return file_paths_with_seed, file_paths_no_seed

seed_root = "report/w_corpus/linux/src"
no_seed_root = "report/w_o_corpus/linux/src"

file_paths_with_seed, file_paths_no_seed = get_file_pairs(seed_root, no_seed_root)

output_file = "report/coverage_comparison_results.txt"
compare_reports_with_multiple_files(file_paths_with_seed, file_paths_no_seed, output_file)

print(f"\n✅ Done! Comparison results saved to: {output_file}")
