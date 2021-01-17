import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '@rampike/shared/environments';

@Component({
  selector: 'rampike-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent {
  isProdClient: boolean;
  version$: Observable<string>;
  isProdApi$: Observable<boolean>;
  constructor(private readonly http: HttpClient) {
    this.isProdClient = environment.production;
    this.version$ = this.http.get<string>('https://api.rampike.de/version');
    this.isProdApi$ = this.http.get<boolean>('https://api.rampike.de/production');
  }
}
