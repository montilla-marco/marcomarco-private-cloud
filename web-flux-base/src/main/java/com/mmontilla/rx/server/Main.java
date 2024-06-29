package com.mmontilla.rx.server;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Main {

	private static Logger logger = LoggerFactory.getLogger(Main.class);
	public static void main(String[] args) {
		//TODO get properties from gradle file for name and version
		logger.info("Starting webflux application");
		SpringApplication.run(Main.class, args);
	}

}
