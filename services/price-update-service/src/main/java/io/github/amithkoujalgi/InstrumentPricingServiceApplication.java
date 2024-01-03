package io.github.amithkoujalgi;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.stream.annotation.EnableBinding;
import org.springframework.cloud.stream.messaging.Processor;
import org.springframework.integration.annotation.Transformer;

@SpringBootApplication
@EnableBinding(Processor.class)
public class InstrumentPricingServiceApplication {
  Logger logger = LoggerFactory.getLogger(InstrumentPricingServiceApplication.class);

  public static void main(String[] args) {
    SpringApplication.run(InstrumentPricingServiceApplication.class, args);
  }

  @Transformer(inputChannel = Processor.INPUT, outputChannel = Processor.OUTPUT)
  public List<Instrument> updateInstrumentPrice(List<Instrument> instruments) {
    List<Instrument> updatedInstrumentList = new ArrayList<>();
    for (Instrument instrument : instruments) {
      updatedInstrumentList.add(applyPrice(instrument));
    }
    return updatedInstrumentList;
  }

  private Instrument applyPrice(Instrument instrument) {
    double randomDouble = getRandomDoubleInRange(10.0, 100.0);
    instrument.setPrice(randomDouble);
    logger.info(
        "Instrument {} price updated to {} at {}.",
        instrument.getName(),
        instrument.getPrice(),
        instrument.getTimestamp());
    return instrument;
  }

  public static double getRandomDoubleInRange(double min, double max) {
    if (min >= max) {
      throw new IllegalArgumentException("Max must be greater than min");
    }
    double randomValue = min + (max - min) * new Random().nextDouble();
    return Math.round(randomValue * 100.0) / 100.0;
  }
}
