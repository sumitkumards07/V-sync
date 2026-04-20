import json
import os

input_file = 'VIT_AP_April_2026_Mess_Menu_Combined.json'
output_file = 'lib/features/campus/data/april_mess_menu.dart'

def generate_dart():
    if not os.path.exists(input_file):
        print(f"Error: {input_file} not found.")
        return

    with open(input_file, 'r') as f:
        data = json.load(f)

    dart_content = [
        "import 'package:vsync/features/campus/data/campus_home_models.dart';",
        "",
        "class MealTimings {",
        "  static const Map<String, String> data = {",
        "    'Breakfast': '07:30 AM - 09:00 AM',",
        "    'Lunch':     '12:00 PM - 02:00 PM',",
        "    'Snacks':    '04:30 PM - 05:45 PM',",
        "    'Dinner':    '07:30 PM - 09:15 PM',",
        "  };",
        "}",
        "",
        "/// A Map where the key is the DAY OF THE MONTH (1-31).",
        "/// The rotation is strictly date-based as per the 2026 menu.",
        "final Map<int, DayMenu> aprilMessMenu = _generateAprilMenu();",
        "",
        "Map<int, DayMenu> _generateAprilMenu() {",
        "  final Map<int, DayMenu> menu = {};",
        ""
    ]

    for entry in data:
        day = entry.get('Date')
        if day is None:
            continue
        
        reg = entry.get('Regular (Veg & Non-Veg)', {})
        spec = entry.get('Special', {})

        def fmt_list(items):
            if not items: return "[]"
            # Escape single quotes and join
            escaped = [item.replace("'", "\\'") for item in items]
            return "[" + ", ".join([f"'{i}'" for i in escaped]) + "]"

        dart_content.append(f"  menu[{day}] = DayMenu(")
        dart_content.append(f"    day: 'Day {day}',")
        dart_content.append(f"    breakfast: {fmt_list(reg.get('Breakfast', []))},")
        dart_content.append(f"    lunch: {fmt_list(reg.get('Lunch', []))},")
        dart_content.append(f"    snacks: {fmt_list(reg.get('Snacks', []))},")
        dart_content.append(f"    dinner: {fmt_list(reg.get('Dinner', []))},")
        dart_content.append("  );")
        dart_content.append("")

    dart_content.append("  return menu;")
    dart_content.append("}")
    dart_content.append("")
    dart_content.append("class DayMenu {")
    dart_content.append("  final String day;")
    dart_content.append("  final List<String> breakfast;")
    dart_content.append("  final List<String> lunch;")
    dart_content.append("  final List<String> snacks;")
    dart_content.append("  final List<String> dinner;")
    dart_content.append("")
    dart_content.append("  DayMenu({")
    dart_content.append("    required this.day,")
    dart_content.append("    required this.breakfast,")
    dart_content.append("    required this.lunch,")
    dart_content.append("    required this.snacks,")
    dart_content.append("    required this.dinner,")
    dart_content.append("  });")
    dart_content.append("")
    dart_content.append("  List<MealData> get meals => [")
    dart_content.append("    MealData(type: 'Breakfast', items: breakfast),")
    dart_content.append("    MealData(type: 'Lunch', items: lunch),")
    dart_content.append("    MealData(type: 'Snacks', items: snacks),")
    dart_content.append("    MealData(type: 'Dinner', items: dinner),")
    dart_content.append("  ];")
    dart_content.append("}")
    dart_content.append("")
    dart_content.append("class MealData {")
    dart_content.append("  final String type;")
    dart_content.append("  final List<String> items;")
    dart_content.append("")
    dart_content.append("  MealData({")
    dart_content.append("    required this.type,")
    dart_content.append("    required this.items,")
    dart_content.append("  });")
    dart_content.append("}")

    with open(output_file, 'w') as f:
        f.write("\n".join(dart_content))
    
    print(f"Successfully generated {output_file} with {len(data)} daily entries.")

if __name__ == "__main__":
    generate_dart()
