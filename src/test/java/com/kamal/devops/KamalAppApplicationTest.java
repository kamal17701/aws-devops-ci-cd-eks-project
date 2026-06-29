package com.kamal.devops;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class KamalAppApplicationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void healthEndpoint_returns200_withStatusUp() throws Exception {
        mockMvc.perform(get("/health"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.status").value("UP"))
               .andExpect(jsonPath("$.timestamp").exists());
    }

    @Test
    void infoEndpoint_returns200_withAppMetadata() throws Exception {
        mockMvc.perform(get("/info"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.app").value("kamalapp"))
               .andExpect(jsonPath("$.version").value("1.5.0"));
    }
}
