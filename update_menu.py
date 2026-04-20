import json
import os

input_file = 'VIT_AP_April_2026_Mess_Menu_Combined.json'
output_file = 'menu_by_date.json'

def transform_menu():
    if not os.path.exists(input_file):
        print(f"Error: {input_file} not found.")
        return

    with open(input_file, 'r') as f:
        data = json.load(f)

    new_menu = {}

    for entry in data:
        day = entry.get('Date')
        if day is None:
            continue
        
        # Format date as 2026-04-DD
        date_str = f"2026-04-{str(day).zfill(2)}"
        
        # Map keys
        veg_non_veg = entry.get('Regular (Veg & Non-Veg)', {})
        special = entry.get('Special', {})
        
        new_menu[date_str] = {
            "Veg & Non-Veg": veg_non_veg,
            "Special": special
        }

    # Write output (completely replacing old data as per user request)
    with open(output_file, 'w') as f:
        json.dump(new_menu, f, indent=4)
    
    print(f"Successfully updated {output_file} with {len(new_menu)} entries.")

if __name__ == "__main__":
    transform_menu()
