package org.c3s.generator.command.process;

import lombok.Getter;

import java.util.Arrays;

public enum Processes {
    DOCUMENT(new XMLProcess()),
    POJO(new VelocityProcess())
    ;
    @Getter
    private GeneralProcess process;

    Processes(GeneralProcess process) {
        this.process = process;
    }

    public static Processes getApplicableProcess(String fileName) {
        Processes result = Arrays.stream(values()).filter(x -> x.process.getTransformer().isApplicable(fileName)).findFirst().orElse(null);
        return result;
    }
}
