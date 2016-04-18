package com.zrb.options.db;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.flywaydb.core.Flyway;

public class FlywayLauncher {

  public static void main(String[] args) throws IOException {
    if (System.getProperty("flyway.configFile") == null) {
      System.err.println("Incorrect usage. Please, specify -Dflyway.configFile parameter");
      System.exit(1);
    }

    Properties properties = new Properties();
    try (InputStream in = new FileInputStream(System.getProperty("flyway.configFile"))) {
      properties.load(in);
    }
    new FlywayLauncher(properties).run((args.length > 0) ? args[0] : null);
    System.exit(0);
  }

  private final Properties properties;

  public FlywayLauncher() throws IOException {
    if (System.getProperty("flyway.configFile") == null) {
      System.err.println("Incorrect usage. Please, specify -Dflyway.configFile parameter");
      System.exit(1);
    }

    Properties properties = new Properties();
    try (InputStream in = new FileInputStream(System.getProperty("flyway.configFile"))) {
      properties.load(in);
    }
    this.properties = properties;
  }

  public FlywayLauncher(Properties properties) {
    this.properties = properties;
  }

  public void run(String command) {
    String urlProp = properties.getProperty("flyway.url");
    String userProp = properties.getProperty("flyway.user");
    String passwordProp = properties.getProperty("flyway.password");
    String locations = properties.getProperty("flyway.locations");

    Flyway flyway = new Flyway();
    flyway.setLocations(locations.split(","));
    flyway.setDataSource(urlProp, userProp, passwordProp);
    if ("clean".equals(command)) {
      flyway.clean();
    } else if ("repair".equals(command)) {
      flyway.repair();
    } else {
      flyway.migrate();
    }
  }
}
