package com.bring.developer.config;

import org.apache.http.client.HttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.CoreConnectionPNames;
import org.apache.http.params.HttpParams;
import org.constretto.ConstrettoConfiguration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.bring.developer.web.Menu;

@Configuration
public class ApplicationConfig {
    
    ConstrettoConfiguration config;
    
    @Autowired
    public void setConstrettoConfig(ConstrettoConfiguration config) {
        this.config = config;
    }
    
    @Bean
    public HttpClient createHttpClient() {
        HttpParams params = new BasicHttpParams();
        params.setParameter(CoreConnectionPNames.CONNECTION_TIMEOUT, config.evaluateToInt("http.client.connection.timeout"));
        params.setParameter(CoreConnectionPNames.SO_TIMEOUT, config.evaluateToInt("http.client.socket.timeout"));
        ThreadSafeClientConnManager connectionManager = new ThreadSafeClientConnManager();
        return new DefaultHttpClient(connectionManager, params); 
    }
    
    @Bean
    public Menu createMenu() {
		return new Menu();
    }
}
