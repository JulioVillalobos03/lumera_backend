package com.lumera.lumera_erp.modules.plan.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Plan {

    @Id
    @Column(columnDefinition = "BINARY(16)")
    private UUID id;

    @Column(nullable = false, length = 80)
    private String name;

    @Column(nullable = false, length = 50)
    private String code;

    @Column(name = "price_cents", nullable = false)
    private Integer priceCents;

    @Column(nullable = false, length = 3)
    private String currency;

    @Column(name = "max_users", nullable = false)
    private Integer maxUsers;

    @Column(name = "max_storage_mb", nullable = false)
    private Integer maxStorageMb;

    @Column(nullable = false, length = 30)
    private String status;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    public void prePersist() {
        if (id == null) {
            id = UUID.randomUUID();
        }
        createdAt = Instant.now();
    }
}
