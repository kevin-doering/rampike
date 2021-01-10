import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Message } from '@rampike/shared/interfaces';
import { Observable } from 'rxjs';
import { environment } from '@rampike/shared/environments';

@Component({
  selector: 'rampike-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent {
  isProd: boolean;
  response$: Observable<Message>;
  test$: Observable<boolean>;
  constructor(private readonly http: HttpClient) {
    this.isProd = environment.production;
    this.response$ = this.http.get<Message>('http://localhost:3333/api/');
    this.test$ = this.http.get<boolean>('http://localhost:3333/api/env');
  }
}
