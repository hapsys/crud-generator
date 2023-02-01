package ru.aeroflot.generator.utils;

public class Utils {
    public static String generateName(String name, boolean isMethod) {
        StringBuilder ret_name = new StringBuilder();
        boolean flag = !isMethod;
        for(int i=0; i < name.length(); i++) {
            if(name.charAt(i) == '_') {
                flag = true;
            } else {
                Character chr = name.charAt(i);
                if (flag) {
                    ret_name.append(Character.toUpperCase(chr));
                } else {
                    ret_name.append(Character.toLowerCase(chr));
                }
                flag = false;
            }
        }
        return ret_name.toString();
    }

    public static String generateClassName(String name) {
        return generateName(name, false);
    }

    public static String generateMethodName(String name) {
        return generateName(name, true);
    }
}
