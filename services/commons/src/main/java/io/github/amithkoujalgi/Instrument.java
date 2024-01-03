package io.github.amithkoujalgi;

import java.util.Date;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Instrument {
  private String name;
  private double price;
  private Date timestamp;
}
