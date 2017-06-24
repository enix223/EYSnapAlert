# EYSnapAlert

A simple alert box designed for iOS, with simple API. 

-----

# Installation

## Pod
```ruby
pod 'EYSnapAlert'
```

## Manually

Drag 'EYSnapAlert.swift' to your project

# Usage

### Show an alert with default values

Show a alert with a single line

```swift
EYSnapAlert.show(message: "世界，你好", onTap: nil, onDimiss: nil)
```

### Show an alert with user specific parameters

```swift
EYSnapAlert.show(message: String(format: "你好，世界, [Style: %@]", cell.textLabel!.text!),
                 backgroundColor: UIColor.black,
                 textSize: 12,
                 textColor: UIColor.white,
                 duration: 3,
                 cornerRadius: 5,
                 style: .fade,
                 onTap: { (alert) in
                    print("Alert is tap...")
                 },
                 onDimiss: {() in
                    print("Alert was dismissed")
                 })
```

For more detail, please refer to the Example project.
