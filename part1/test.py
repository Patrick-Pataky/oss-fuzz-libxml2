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

# --- Compare reports ---
with_seed = extract_red_lines("coverage/coverageXmlSeed/linux/src/SAX2.c.html")
no_seed = extract_red_lines("coverage/coverageXmlNoSeed2/linux/src/SAX2.c.html")


only_with_seed = with_seed - no_seed
only_without_seed = no_seed - with_seed

print("Uncovered lines only with seed:")
for line in sorted(only_with_seed):
    print(f"  Line {line}")

print("\nUncovered lines only without seed:")
for line in sorted(only_without_seed):
    print(f"  Line {line}")

