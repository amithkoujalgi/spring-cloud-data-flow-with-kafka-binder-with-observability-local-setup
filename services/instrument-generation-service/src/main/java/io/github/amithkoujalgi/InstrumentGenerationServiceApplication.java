package io.github.amithkoujalgi;

import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.stream.annotation.EnableBinding;
import org.springframework.cloud.stream.messaging.Source;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.annotation.InboundChannelAdapter;
import org.springframework.integration.annotation.Poller;
import org.springframework.integration.core.MessageSource;
import org.springframework.messaging.support.MessageBuilder;

@SpringBootApplication
@EnableBinding(Source.class)
public class InstrumentGenerationServiceApplication {

  @Value("${instrument.names}")
  List<String> instrumentNames;

  Logger logger = LoggerFactory.getLogger(InstrumentGenerationServiceApplication.class);

  @Bean
  @InboundChannelAdapter(
      value = Source.OUTPUT,
      poller = @Poller(fixedDelay = "1000", maxMessagesPerPoll = "1"))
  public MessageSource<List<Instrument>> produceInstruments() {
    String randomInstrument = instrumentNames.get(new Random().nextInt(instrumentNames.size()));
    List<Instrument> instruments =
        Stream.of(new Instrument(randomInstrument, 0, new Date())).collect(Collectors.toList());
    logger.info("Producing random instrument: {}", instruments);
    return () -> MessageBuilder.withPayload(instruments).build();
  }

  public static void main(String[] args) {
    SpringApplication.run(InstrumentGenerationServiceApplication.class, args);
  }
}
