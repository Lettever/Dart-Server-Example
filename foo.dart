import 'dart:io';

void main() {
    /*
    var counter = () {
        int value = 0;
        return (
            {bool increment = false}
        ) {
            if (increment) value++;
            return value;
        };
    }();
     */
    var foo = () {
        int num = 0;

        return (
            value: () => num,
            add: (int n) => num += n
        );
    }();

    while(true) {
        print(">> ");
        String? name  = stdin.readLineSync();
        if (name == null || name == "") {
            break;
        }
        if (name == 'value') print(foo.value());
        else if (name == 'add') foo.add(1);
    }
}