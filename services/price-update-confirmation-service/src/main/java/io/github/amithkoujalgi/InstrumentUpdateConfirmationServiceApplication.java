package io.github.amithkoujalgi;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.stream.annotation.EnableBinding;
import org.springframework.cloud.stream.annotation.StreamListener;
import org.springframework.cloud.stream.messaging.Sink;

@SpringBootApplication
@EnableBinding(Sink.class)
public class InstrumentUpdateConfirmationServiceApplication {

  Logger logger = LoggerFactory.getLogger(InstrumentUpdateConfirmationServiceApplication.class);

  @StreamListener(Sink.INPUT)
  public void confirmPriceUpdate(List<Instrument> instruments) {
    instruments.forEach(
        instrument -> {
          logger.info(
              "Instrument {} price updated to {} at {} and is ready to be traded.",
              instrument.getName(),
              instrument.getPrice(),
              instrument.getTimestamp());
        });
  }

  public static void main(String[] args) {
    SpringApplication.run(InstrumentUpdateConfirmationServiceApplication.class, args);
  }
}
