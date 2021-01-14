package models;

import javax.inject.*;

import play.db.*;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.Executor;

@Singleton
public class PostgresDatabase {

  private Database db;

  @Inject
  public PostgresDatabase(Database db) {
    this.db = db;
  }

  public CompletionStage<Integer> updateSomething(Executor context) {
    return CompletableFuture.supplyAsync(
        () -> {
          return db.withConnection(
              connection -> {
                // do whatever you need with the db connection
                return 10;
              });
        },
        context);
  }
  public String CheckVariables(Executor context) {
    return String.valueOf(db) + ", " + String.valueOf(context);
  }
}
