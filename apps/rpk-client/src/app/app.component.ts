import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Message } from '@rampike/shared/interfaces';
import { environment } from '@rampike/shared/environments';

@Component({
  selector: 'rampike-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent {
  mode: string;
  hello$ = this.http.get<Message>('http://localhost:3333/api/hello');
  constructor(private http: HttpClient) {
    this.mode = environment.production ? 'prod' : 'dev';
  }
}
