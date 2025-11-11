#!/usr/bin/env python3
import os
import re

def convert_preview_to_provider(content, filename):
    """Convert #Preview to PreviewProvider format"""
    
    # Pattern to match #Preview { ... }
    preview_pattern = r'#Preview\s*\{([^}]+)\}'
    
    def replace_preview(match):
        preview_content = match.group(1).strip()
        
        # Extract the view name from the filename
        view_name = os.path.splitext(os.path.basename(filename))[0]
        
        # Create PreviewProvider struct
        provider_struct = f"""struct {view_name}_Previews: PreviewProvider {{
    static var previews: some View {{
        {preview_content}
    }}
}}"""
        return provider_struct
    
    # Replace all #Preview occurrences
    updated_content = re.sub(preview_pattern, replace_preview, content, flags=re.DOTALL)
    
    return updated_content

def process_file(filepath):
    """Process a single Swift file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if '#Preview' not in content:
            return False
        
        print(f"Processing: {filepath}")
        updated_content = convert_preview_to_provider(content, filepath)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(updated_content)
        
        return True
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    views_dir = "/Users/romirjain/Desktop/building projects/Offleaf/Offleaf/Offleaf/Views"
    main_dir = "/Users/romirjain/Desktop/building projects/Offleaf/Offleaf/Offleaf"
    
    fixed_count = 0
    
    # Process Views directory
    for filename in os.listdir(views_dir):
        if filename.endswith('.swift'):
            filepath = os.path.join(views_dir, filename)
            if process_file(filepath):
                fixed_count += 1
    
    # Process main directory (ContentView.swift, etc.)
    for filename in os.listdir(main_dir):
        if filename.endswith('.swift') and filename not in ['OffleafApp.swift']:
            filepath = os.path.join(main_dir, filename)
            if process_file(filepath):
                fixed_count += 1
    
    print(f"\nFixed {fixed_count} files with #Preview issues")

if __name__ == "__main__":
    main()
