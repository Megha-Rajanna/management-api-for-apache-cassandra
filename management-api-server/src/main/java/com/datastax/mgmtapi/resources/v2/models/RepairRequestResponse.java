package com.datastax.mgmtapi.resources.v2.models;

import java.util.Objects;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

public class RepairRequestResponse {
  @JsonProperty(value = "repair_id", required = true)
  public final String repairID;
  @JsonCreator
  public RepairRequestResponse(@JsonProperty(value = "repair_id", required = true) String repairID) {
    this.repairID = repairID;
  }

  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    return Objects.equals(repairID, ((RepairRequestResponse) o).repairID);
  }

  public int hashCode() {
    return Objects.hashCode(repairID);
  }
}