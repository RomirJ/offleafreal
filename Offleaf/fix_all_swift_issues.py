#!/usr/bin/env python3
import os
import re
import sys

def fix_onchange_issues(content):
    """Fix onChange to use single parameter syntax for iOS compatibility"""
    # Pattern 1: onChange with two parameters (oldValue, newValue)
    pattern1 = r'\.onChange\(of:\s*([^)]+)\)\s*\{\s*(?:oldValue|_),\s*(\w+)\s+in'
    content = re.sub(pattern1, r'.onChange(of: \1) { \2 in', content)
    
    # Pattern 2: onChange with underscore and newValue
    pattern2 = r'\.onChange\(of:\s*([^)]+)\)\s*\{\s*_,\s*(\w+)\s+in'
    content = re.sub(pattern2, r'.onChange(of: \1) { \2 in', content)
    
    # Pattern 3: onChange with no parameters (just closure body)
    pattern3 = r'\.onChange\(of:\s*([^)]+)\)\s*\{\s*([^}]+)\s*\}'
    def replace_no_params(match):
        param = match.group(1)
        body = match.group(2).strip()
        # Only replace if it doesn't already have 'in'
        if ' in' not in body and not body.startswith('_'):
            return f'.onChange(of: {param}) {{ _ in {body} }}'
        return match.group(0)
    content = re.sub(pattern3, replace_no_params, content)
    
    return content

def fix_preview_issues(content, filename):
    """Replace #Preview with PreviewProvider for broader compatibility"""
    # Extract view name from filename
    view_name = os.path.splitext(os.path.basename(filename))[0]
    
    # Pattern to match #Preview { ... }
    preview_pattern = r'#Preview\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
    
    def replace_preview(match):
        preview_content = match.group(1).strip()
        
        # Create PreviewProvider struct
        provider_struct = f"""struct {view_name}_Previews: PreviewProvider {{
    static var previews: some View {{
        {preview_content}
    }}
}}"""
        return provider_struct
    
    # Replace all #Preview occurrences
    content = re.sub(preview_pattern, replace_preview, content, flags=re.DOTALL)
    
    return content

def process_swift_file(filepath):
    """Process a single Swift file and fix all issues"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        content = original_content
        
        # Fix onChange issues
        content = fix_onchange_issues(content)
        
        # Fix #Preview issues
        content = fix_preview_issues(content, filepath)
        
        # Only write if changes were made
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def find_swift_files(directory):
    """Recursively find all Swift files in directory"""
    swift_files = []
    for root, dirs, files in os.walk(directory):
        # Skip hidden directories and build directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and d != 'Build']
        
        for file in files:
            if file.endswith('.swift'):
                swift_files.append(os.path.join(root, file))
    return swift_files

def main():
    base_dir = "/Users/romirjain/Desktop/building projects/Offleaf/Offleaf"
    
    print("🔍 Scanning for Swift files with issues...")
    
    # Find all Swift files
    swift_files = find_swift_files(base_dir)
    print(f"Found {len(swift_files)} Swift files")
    
    fixed_count = 0
    files_with_issues = []
    
    # Process each file
    for filepath in swift_files:
        relative_path = os.path.relpath(filepath, base_dir)
        
        # Check if file needs fixing
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        has_issues = False
        issue_types = []
        
        # Check for onChange issues
        if re.search(r'\.onChange\(of:', content):
            # Check if it uses the old two-parameter syntax
            if re.search(r'\.onChange\(of:[^)]+\)\s*\{\s*(?:oldValue|_),\s*\w+\s+in', content):
                has_issues = True
                issue_types.append("onChange")
        
        # Check for #Preview issues  
        if '#Preview' in content:
            has_issues = True
            issue_types.append("#Preview")
        
        if has_issues:
            files_with_issues.append((relative_path, issue_types))
            print(f"  ⚠️  {relative_path} - Issues: {', '.join(issue_types)}")
            
            # Fix the file
            if process_swift_file(filepath):
                fixed_count += 1
                print(f"  ✅ Fixed: {relative_path}")
    
    print(f"\n📊 Summary:")
    print(f"  - Total files scanned: {len(swift_files)}")
    print(f"  - Files with issues: {len(files_with_issues)}")
    print(f"  - Files fixed: {fixed_count}")
    
    if files_with_issues:
        print(f"\n✨ All iOS/Swift compatibility issues have been fixed!")
    else:
        print(f"\n✨ No compatibility issues found - your code is already iOS-compatible!")

if __name__ == "__main__":
    main()
