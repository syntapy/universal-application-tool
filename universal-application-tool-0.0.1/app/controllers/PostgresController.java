package controllers;

import models.DatabaseExecutionContext;
import models.PostgresDatabase;
import play.libs.concurrent.HttpExecution;
import play.libs.concurrent.HttpExecutionContext;
import play.mvc.Controller;
import play.mvc.Result;

import javax.inject.Inject;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.Executor;
import static java.util.concurrent.CompletableFuture.supplyAsync;

public class PostgresController extends Controller {
  public static String homePageString = "This page has been retrieved ";

  private final PostgresDatabase db;
  private final DatabaseExecutionContext dbec;
  private final HttpExecutionContext ec;

  @Inject
  public PostgresController(PostgresDatabase db, DatabaseExecutionContext dbec, HttpExecutionContext ec) {
    this.db = db;
    this.dbec = dbec;
    this.ec = ec;
  }

  public CompletionStage<Result> retrieve() {
    Executor dbe = HttpExecution.fromThread(dbec);
    return db
           .updateSomething(dbe)
           .thenApplyAsync(result -> ok(homePageString + String.valueOf(result) + " times."), ec.current());
  }
  public Result check() {
    Executor dbe = HttpExecution.fromThread(dbec);
    return ok(db.CheckVariables(dbe));
  }

}
